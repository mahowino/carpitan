require "net/http"
require "json"
require "logger"

class FinanceBillVoteUpdater
  def initialize(api_url: Rails.application.config.api_configs["politician_api"],
                 api_client: ApiClient, user_finder: -> { User.first })
    @api_url = api_url
    @api_client = api_client
    @user_finder = user_finder
  end

  def call
    @api_client.get_json(@api_url).each { |data| update_or_create_politician(data) }
  rescue StandardError => e
    logger.error("❌ Unexpected error: #{e.message}")
  end

  private

  def update_or_create_politician(data)
    politician = Politician.find_or_initialize_by(name: data["NAME"])
    politician.update!(position: "Member of parliament", jurisdiction: data["relation_name"],
                       finance_bill_vote: transform_vote(data["vote"]), user: @user_finder.call)
    logger.info("✅ Saved #{politician.name} with vote: #{politician.finance_bill_vote}")
  rescue StandardError => e
    logger.error("❌ Failed to save #{data['NAME']}: #{e.message}")
  end

  def transform_vote(vote)
    { "Y" => "Yes", "N" => "No", "A" => "Abstain", "U" => "Unavailable" }[vote&.upcase] || vote
  end

  def logger = @logger ||= Logger.new(Rails.root.join("log", "finance_bill_updater.log"))
end