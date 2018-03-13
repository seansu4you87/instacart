require "yaml"
require "active_record"

config = YAML::load(File.open("config.yml"))
ActiveRecord::Base.establish_connection(config)
STATE_ORDER = {
  "quiz_started" => 0,
  "quiz_completed" => 1,
  "applied" => 3,
  "onboarding_requested" => 4,
  "onboarding_completed" => 5,
  "hired" => 6,
}

class Applicant < ActiveRecord::Base
end

def analyze(start_date, end_date)
  raw = Applicant.connection.execute(
<<-SQL
SELECT
  COUNT(*) as count,
  STRFTIME('%W %Y', created_at) AS week_of_year,
  created_at,
  workflow_state
FROM applicants
WHERE
  created_at BETWEEN '#{start_date}' AND '#{end_date}'
GROUP BY week_of_year, workflow_state
;
SQL
  )
  raw
    .map do |row|
      monday = row["created_at"].to_date.beginning_of_week.to_date.to_s
      state = row["workflow_state"]
      count = row["count"]
      [[monday, state], count]
    end
    .sort_by { |(monday, state), _| [monday, STATE_ORDER[state]] }
    .tap { |me| pretty(me) }
end

def analyze_orm(start_date, end_date)
  Applicant
    .select("created_at", "workflow_state")
    .where(created_at: start_date..end_date)
    .group_by { |a| [a.created_at.beginning_of_week.to_date, a.workflow_state] }
    .map { |k, v| [k, v.count] }
    .sort_by { |(monday, state), _| [monday, STATE_ORDER[state]] }
    .tap { |me| pretty(me) }
end

def pretty(results)
  puts "#{"count".rjust(10)}, #{"week".rjust(10)}, #{"workflow_state".rjust(30)}"
  results.each do |(monday, state), count|
    string = ""
    string << count.to_s.rjust(10)
    string << ", "
    string << monday.to_s.rjust(10)
    string << ", "
    string << state.rjust(30)
    puts string
  end
  nil
end

@s = "2014-07-14".to_date
@e = "2014-07-21".to_date

start_date = ARGV[0].to_date
end_date = ARGV[1].to_date
puts "Fetching data between #{start_date} and #{end_date}"
analyze(start_date, end_date)

