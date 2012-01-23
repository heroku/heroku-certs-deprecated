require "heroku/command/base"
require "ssl_endpoint/heroku/run_with_status"

# manage ssl endpoints for an app
#
class Heroku::Command::Certs < Heroku::Command::BaseWithApp

  include Heroku::RunWithStatus

  # certs
  #
  # list SSL endpoints for an app
  #
  def index
    endpoints = heroku.ssl_endpoint_list(app)

    if endpoints.empty?
      display "No SSL endpoints setup."
      display "Use 'heroku certs:add <pemfile> <keyfile>' to create a SSL endpoint."
    else
      endpoints.map!{ |e| format_endpoint(e) }
      display_table endpoints, %w( cname domains expires_at ca_signed? ), [ "Endpoint", "Common Name(s)", "Expires", "Trusted" ]
    end
  end

  # certs:add PEM KEY
  #
  # add an SSL endpoint to an app
  #
  def add
    if args.size < 2
      fail("Usage: heroku certs:add PEM KEY")
    end

    pem = File.read(args[0]) rescue error("Unable to read PEM")
    key = File.read(args[1]) rescue error("Unable to read KEY")
    app = self.respond_to?(:app) ? self.app : self.extract_app

    endpoint = nil
    run_with_status("-----> Adding SSL endpoint to #{app}") do
      endpoint = heroku.ssl_endpoint_add(app, pem, key)
    end

    indent(7) do
      display_indented "#{app} now served by #{endpoint['cname']}"
      display_indented "Certificate details:"
      display_certificate_info(endpoint)
    end
  end

  # certs:remove
  #
  # remove an SSL endpoint from an app
  #
  def remove
    cname = options[:endpoint] || current_endpoint
    run_with_status("-----> Removing SSL endpoint #{cname} from #{app}") do
      heroku.ssl_endpoint_remove(app, cname)
    end
    indent(7) do
      display_indented "De-provisioned endpoint #{cname}."
      display_indented "NOTE: Billing is still active. Remove SSL endpoint add-on to stop billing."
    end
  end

  # certs:update PEM KEY
  #
  # update an SSL endpoint on an app
  #
  def update
    if args.size < 2
      fail("Usage: heroku certs:update PEM KEY")
    end

    pem = File.read(args[0]) rescue error("Unable to read PEM")
    key = File.read(args[1]) rescue error("Unable to read KEY")
    app = self.respond_to?(:app) ? self.app : self.extract_app
    cname = options[:endpoint] || current_endpoint

    endpoint = nil
    run_with_status("-----> Updating SSL endpoint #{cname} for #{app}") do
      endpoint = heroku.ssl_endpoint_update(app, cname, pem, key)
    end

    indent(7) do
      display_indented "Updated certificate details:"
      display_certificate_info(endpoint)
    end
  end

  # certs:rollback
  #
  # rollback an SSL endpoint on an app
  #
  def rollback
    cname = options[:endpoint] || current_endpoint
    run_with_status("-----> Rolling back SSL endpoint #{cname} on #{app}") do
      endpoint = heroku.ssl_endpoint_rollback(app, cname)
    end

=begin
    indent(7) do
      display_indented "New active certificate details:"
      display_certificate_info(endpoint)
    end
=end
  end

  private

  TIME_FORMAT = "%Y-%m-%d %H:%M:%S %Z"

  def current_endpoint
    endpoint = heroku.ssl_endpoint_list(app).first || error("No SSL endpoints exist for #{app}")
    endpoint["cname"]
  end

  def display_certificate_info(endpoint)
    endpoint = format_endpoint(endpoint)
    indent(4) do
      display_indented("subject: %s"        % endpoint['subject'])
      display_indented("start date: %s"     % endpoint['starts_at'])
      display_indented("expire date: %s"    % endpoint['expires_at'])
      display_indented("common name(s): %s" % endpoint['domains'])
      display_indented("issuer: %s"         % endpoint['issuer'])
      if endpoint["ssl_cert"]["ca_signed?"]
        display_indented("SSL certificate is verified by a root authority.")
      elsif endpoint["issuer"] == endpoint["subject"]
        display_indented("SSL certificate is self signed.")
      else
        display_indented("SSL certificate is not trusted.")
      end
    end
  end

  def display_indented(str)
    @indent_size ||= 0
    display " " * @indent_size + str
  end

  def format_endpoint(endpoint)
    endpoint["ca_signed?"] = endpoint["ssl_cert"]["ca_signed?"].to_s.capitalize
    endpoint["domains"]    = endpoint["ssl_cert"]["cert_domains"].join(", ")
    endpoint["expires_at"] = Time.parse(endpoint["ssl_cert"]["expires_at"]).strftime(TIME_FORMAT)
    endpoint["issuer"]     = endpoint["ssl_cert"]["issuer"]
    endpoint["starts_at"]  = Time.parse(endpoint["ssl_cert"]["starts_at"]).strftime(TIME_FORMAT)
    endpoint["subject"]    = endpoint["ssl_cert"]["subject"]
    endpoint
  end

  def indent(size)
    @indent_size ||= 0
    @indent_size += size
    yield
    @indent_size -= size
  end

end
