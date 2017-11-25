open Touist.Parser
open Lexing
open Touist.Err

open Touist.Types
open Touist.Types.Ast

(** [lexer] is used [parse] in order to get the next token of the input
    stream. It is an intermediate to the {!Touist.Lexer.token} function (in lexer.ml);
    - Rationale: the parser only accepts Touist.Parser.token; but {!Touist.Lexer.token} returns
      Touist.Parser.token list. [lexer] acts as a buffer, returning one by one the list
      of tokens returned by {!Touist.Lexer.token}.
    - Drawback: ALL tokens must be returned as a list, even though most token
      case returns a single token, e.g.,
        ["=>" { IMPLIES }]   must be translated into     [{ [IMPLIES] }]
    - Note: see details in {!Touist.Lexer.token} (file lexer.ml)

    @raise Touist.Lexer.Error (message, loc) where 'loc' contains the start/end of the
        faulty item
*)
let lexer buffer : (Lexing.lexbuf -> Touist.Parser.token) =
  let tokens = ref [] in (* tokens stored to be processed (see above) *)
  fun lexbuf ->
    match !tokens with
    | x::xs -> tokens := xs; x (* tokens isn't empty, use one of its tokens *)
    | [] -> (* tokens is empty, we can read a new token *)
      let t = Touist.Lexer.token lexbuf in
      buffer := Touist.ParserReport.update !buffer (lexbuf.lex_start_p, lexbuf.lex_curr_p);
      match t with
      | [] -> failwith "One token at least must be returned in 'token rules' "
      | x::xs -> tokens := xs; x

(** [parse] is the main function for parsing touistl. It uses the incremental
    API of menhirLib, which allows us to do our own error handling.

    [parser] is the 'entry point' of the parser that is defined in
    parser.mly, i.e.,   {[
        %start <Touist.Types.Ast.t> touist_simple, touist_smt
    ]}

    [detailed_err] allows to display absolute positions of the faulty text.

    Example for calling [parse]:   {[
      parse Touist.Parser.Incremental.touist_simple "let î = 1: p($i)"
    ]}

    WARNING: for now, the 'pos_fname' that should contain the filename
    needed by menhirlib (just for error handling) contains
    "foo.touistl"... For now, the name of the input file name is not
    indicated to the user: useless because we only handle a single touistl file
*)
let parse (parser) ?debug:(debug=false) filename (text:string) : Ast.t =
  let buffer = ref Touist.ParserReport.Zero in
  let lexbuf = Lexing.from_string text in
  lexbuf.lex_curr_p <- {lexbuf.lex_curr_p with pos_fname = filename; pos_lnum = 1};
  let checkpoint = parser lexbuf.lex_curr_p
  and supplier = Touist.Parser.MenhirInterpreter.lexer_lexbuf_to_supplier (lexer buffer) lexbuf
  and succeed ast = ast
  and fail checkpoint =
    let msg = (Touist.ParserReport.report text !buffer checkpoint debug)
    and loc = Touist.ParserReport.area_pos !buffer (* area_pos returns (start_pos,end_pos) *)
    in fatal (Error,Parse,msg,Some loc)
  in
    let ast =
      try Touist.Parser.MenhirInterpreter.loop_handle succeed fail supplier checkpoint
      with Touist.Lexer.Error (msg,loc) -> Touist.Err.fatal (Error,Lex,msg,Some loc)
    in ast

(** Directly calls [parser] with [Touist.Parser.Incremental.touist_simple] *)
let parse_sat ?debug_syntax:(d=false) ?(filename="foo.touistl") text = parse Touist.Parser.Incremental.touist_simple ~debug:d filename text

(** Same for [Touist.Parser.Incremental.touist_simple] *)
let parse_smt ?debug_syntax:(d=false) ?(filename="foo.touistl") text = parse Touist.Parser.Incremental.touist_smt ~debug:d filename text

(** Same for [Touist.Parser.Incremental.touist_qbf] *)
let parse_qbf ?debug_syntax:(d=false) ?(filename="foo.touistl") text = parse Touist.Parser.Incremental.touist_qbf ~debug:d filename text


(** [string_of_channel] takes an opened file and returns a string of its content. *)
let string_of_chan (input:in_channel) : string =
  let text = ref "" in
  try
    while true do
      text := !text ^ (input_line input) ^ "\n"
    done; ""
  with End_of_file -> !text

(** [string_of_file] opens the given file and returns a string of its content. *)
let string_of_file (name:string) : string =
  string_of_chan (open_in name)