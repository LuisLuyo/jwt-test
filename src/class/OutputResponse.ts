export class OutputResponse {
    type: string;
    severity: string;
    http_status: string;
    code: string;
    message: string;
    hint: string;
    constructor(_type: string, _severity: string, _http_status: string, _code: string, _message: string, _hint: string,) {
        this.type = _type;
        this.severity = _severity;
        this.http_status = _http_status;
        this.code = _code;
        this.message = _message;
        this.hint = _hint;
    }
}