(* Programa pequeno e valido: nenhum ERROR esperado. *)
class Main inherits IO {
  count : Int <- 0;
  flag : Bool <- true;

  main() : Object {
    {
      -- incrementa ate 3
      while count < 3 loop
        count <- count + 1
      pool;
      if not flag then out_string("falso\n") else out_string("verdadeiro\n") fi;
      let s : String <- "fim" in out_string(s);
      case self of o : Object => isvoid o; esac;
      new SELF_TYPE;
    }
  };
};
