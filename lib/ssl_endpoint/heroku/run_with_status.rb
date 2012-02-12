module Heroku::RunWithStatus

  def run_with_status(status)
    display "-----> #{status}... ", false
    begin
      yield
    rescue RestClient::RequestTimeout
      error_with_failure "API request timed out. Please try again, or contact support@heroku.com if this issue persists."
    rescue RestClient::RequestFailed => e
      error_with_failure Heroku::Command.extract_error(e.http_body)
    rescue RestClient::ResourceNotFound => e
      error_with_failure Heroku::Command.extract_error(e.http_body) {
        e.http_body =~ /^[\w\s]+ not found$/ ? e.http_body : "Resource not found"
      }
    end
    display "done"
  end

end
