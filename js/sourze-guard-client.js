export class SourzeGuardClient {
  constructor(ffiBridge) {
    this.ffi = ffiBridge; // WebAssembly or Node.js FFI binding
  }
  
  async checkSourze(policy) {
    const msg = { kind: "SOURZE_POLICY", payload: policy };
    const resp = await this.ffi.evalAlnEnvelope(JSON.stringify(msg));
    const decision = JSON.parse(resp);
    
    if (decision.Approved) {
      return { allowed: true, envelope: decision.Approved.envelope };
    } else if (decision.Quarantine) {
      return { allowed: false, reason: `QUARANTINE: ${decision.Quarantine.reason}` };
    } else if (decision.Blocked) {
      return { allowed: false, reason: `BLOCKED: ${decision.Blocked.reason}` };
    }
    throw new Error("Invalid decision format");
  }
}
