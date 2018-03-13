require "yaml"
require "active_record"

config = YAML::load(File.open("config.yml"))
ActiveRecord::Base.establish_connection(config)

class Applicant < ActiveRecord::Base
end

def analyze
  raw = Applicant.connection.execute(
<<-SQL
SELECT
  COUNT(*),
  STRFTIME('%W %Y', created_at, 'localtime', 'weekday 0', '-6 days') AS week,
  created_at,
  workflow_state
FROM applicants
WHERE
  created_at BETWEEN '2014-07-01' AND '2014-09-01'
GROUP BY workflow_state;
SQL
)
end

def pretty(raw)
  puts "#{"count".ljust(10)}, #{"week".ljust(10)}, #{"workflow_state".ljust(10)}"
  raw.each do |row|
    puts "#{row["COUNT(*)"].to_s.ljust(10)}, #{row["created_at"][0...10].ljust(10)}, #{row["workflow_state"].ljust(10)}"
  end
end

