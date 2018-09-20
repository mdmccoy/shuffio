class Team < ApplicationRecord
  after_create :set_default_elo

  has_and_belongs_to_many :divisions
  has_many :seasons, through: :divisions

  def set_default_elo
    self.elo_cache = starting_elo || 1500
    save
  end

  def matches
    Match.where(away_team_id: id).or(Match.where(home_team_id: id))
  end

  def record(team_matches = matches)
    record = { wins: 0, losses: 0 }

    return record unless team_matches.any?

    team_matches.each do |m|
      if m.winner.nil?
        # do nothing
      elsif m.winner == self
        record[:wins] += 1
      else
        record[:losses] +=1
      end
    end

    record
  end

  def league_record(division = nil)
    # If Division specified, return record from this division
    # Else, return record from _all_ division games
    division ? record(matches.where(division: division)) : record(matches.where.not(division: nil))
  end
end
