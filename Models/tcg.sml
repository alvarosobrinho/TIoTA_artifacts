(* implementation of the test case specification for the TPC example *)

structure TPCTCSpec : TCSPEC = struct
	  
fun detection (Bind.Producer'Request_token_producer _)  = true
  | detection (Bind.Consumer'Receive_encrypted_data _)  = true
  | detection (Bind.Consumer'Decripted _)  = true
  | detection (Bind.Producer'Receive_token_producer_and_request_to_KV _)  = true
  | detection (Bind.Producer'Publish_encrypted_data _)  = true
  | detection _ = false;

exception obsExn;
fun observation (Bind.Producer'Request_token_producer (_, {prod_id, 
prod_cert})) = [InEvent (Credential(prod_id, prod_cert))]
  | observation (Bind.Producer'Receive_token_producer_and_request_to_KV (_, {prod_id,valid_token,a})) = [OutEvent (Authenticated(true))]
  | observation (Bind.Producer'Publish_encrypted_data (_, {prod_id,token,pub_key,m})) = [InEvent (Published(m))]
  | observation (Bind.Consumer'Receive_encrypted_data (_, {prod_id, value})) = [OutEvent (Data(value))]
  | observation (Bind.Consumer'Decripted (_, {nvalue})) = [OutEvent (Data(nvalue))]  
  | observation _ = raise obsExn; 


fun format (InEvent (Credential(prod_id, 
prod_cert))) =
  "      <Standard>\n"^
  "        <Insulin>^c^</Insulin>\n"^
  "      </Standard>\n"
  | format (OutEvent (Data(value))) =
    "        <Decision>\n"^
    "          <DecisionValue></DecisionValue>\n"^
    "        </Decision>\n";
end;

(* setup test case generation for the TPC example *)
Config.setTCdetect(TPCTCSpec.detection);
Config.setTCobserve(TPCTCSpec.observation);
Config.setTCformat(TPCTCSpec.format);

(* logging and output *)
Config.setModelDir (mbtcpnlibpath^"examples/TIoTA/");
Config.setOutputDir ((Config.getModelDir())^"tests/");

(* configuration and test case naming *)
Config.setConfigNaming (fn () => "tiotatc");
Config.setTCNaming(fn i => "CaseID=\""^(Int.toString i)^"\" NumOf=\"");
