local cjson = require("cjson.safe")

local SourzeGuardClient = {}

-- FFI hook to Rust sovereign core
local function rust_eval_aln_envelope(encoded)
  error("rust_eval_aln_envelope FFI not bound in test environment")
end

function SourzeGuardClient.check_sourze(policy_table)
  local msg = { kind = "SOURZE_POLICY", payload = policy_table }
  local encoded = cjson.encode(msg)
  local resp = rust_eval_aln_envelope(encoded)
  local decision = cjson.decode(resp)
  
  if decision and decision.Approved then
    return true, decision.Approved.envelope
  elseif decision and decision.Quarantine then
    return false, nil, "QUARANTINE: " .. decision.Quarantine.reason
  elseif decision and decision.Blocked then
    return false, nil, "BLOCKED: " .. decision.Blocked.reason
  else
    return false, nil, "INVALID_DECISION"
  end
end

return SourzeGuardClient
