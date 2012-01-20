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
      endpoints.map! do |endpoint|
        endpoint["ca_signed?"] = endpoint["ssl_cert"]["ca_signed?"].to_s.capitalize
        endpoint["domain"]     = endpoint["ssl_cert"]["cert_domains"].join(", ")
        endpoint["expires"]    = Time.parse(endpoint["ssl_cert"]["expires_at"]).strftime("%Y-%m-%d %H:%M:%S %Z")
        endpoint
      end

      display_table endpoints, %w( cname domain expires ca_signed? ), [ "Endpoint", "Common Name(s)", "Expires", "Trusted" ]
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

    info = nil
    run_with_status("-----> Adding SSL endpoint to #{app}") do
      info = heroku.ssl_endpoint_add(app, pem, key)
    end

    display_indented "#{app} now served by #{info['cname']}"
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
    display_indented "De-provisioned endpoint #{cname}."
    display_indented "NOTE: Billing is still active. Remove SSL endpoint add-on to stop billing."
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

    run_with_status("-----> Updating SSL endpoint #{cname} for #{app}") do
      heroku.ssl_endpoint_update(app, cname, pem, key)
    end
  end

  # certs:rollback
  #
  # rollback an SSL endpoint on an app
  #
  def rollback
    cname = options[:endpoint] || current_endpoint
    run_with_status("-----> Rolling back SSL endpoint #{cname} on #{app}") do
      heroku.ssl_endpoint_rollback(app, cname)
    end
  end

  private

  def current_endpoint
    endpoint = heroku.ssl_endpoint_list(app).first || error("No SSL endpoints exist for #{app}")
    endpoint["cname"]
  end

  def display_indented(str)
    display "       " + str
  end

end
