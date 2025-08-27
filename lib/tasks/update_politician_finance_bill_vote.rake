# lib/tasks/politicians.rake
namespace :politicians do
  desc "Fetch and update politicians from API"
  task fetch_and_update: :environment do
    FinanceBillVoteUpdater.new.call
    puts "✅ Politicians updated!"
  end
end
