class Api::V1::StatusesController < Api::V1::ApplicationController
  skip_before_action :verify_token

  def commits
    commits = File.read("#{Rails.root}/../commits.txt").split("\n")
    maps = %w(frontend backend orderbot odds_service).reduce({}) do |result, project|
      result[project] = commits[commits.index(project) + 1].sub("commit ", "")
      result
    end
    begin
      maps['afu-entertainment'] = File.read("#{Rails.root}/../.mina_git_revision")
    rescue
      maps['afu-entertainment'] = ""
    end
    render json: maps
  rescue
    maps = %w(frontend backend orderbot odds_service).reduce({}) do |result, project|
      result[project] = "伺服器錯誤"
      result
    end
    render json: maps
  end
end
