module C = Configurator.V1

let detect_accelerate () =
  match Cpuid.supports [`SSSE3; `AES; `PCLMULQDQ] with
  | Ok r -> r
  | Error _ -> false

let use_accelerate () =
  match Sys.getenv "NOCRYPTO_ACCELERATE" with
  | s -> bool_of_string s
  | exception Not_found -> detect_accelerate ()

let flags () =
  if use_accelerate () then
    ["-DACCELERATE -mssse3 -maes -mpclmul"]
  else
    []

let () =
  let output_path = ref "" in
  let args =
    let key = "--output" in
    let spec = Arg.Set_string output_path in
    let doc = "where the configuration should be written" in
    [(key, spec, doc)]
  in
  C.main ~args ~name:"nocrypto" (fun _ ->
      C.Flags.write_sexp !output_path (flags ()) )
