# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, groups,problems'
    create_accounts
    create_problems
    create_groups
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
GRP_INFO = YAML.load_file("#{DIR}/groups_seed.yml")
PROB_INFO = YAML.load_file("#{DIR}/problems_seed.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    Credence::Account.create(account_info)
  end
end

def create_problems
  prob_info_each = PROBLEM_INFO.each
  groups_cycle = Wefix::Group.all.cycle
  loop do
    prob_info = prob_info_each.next
    group = groups_cycle.next
    Wefix::CreateProblemForGroup.call(
      group_id: group.id, problem_data: prob_info
    )
  end
end
