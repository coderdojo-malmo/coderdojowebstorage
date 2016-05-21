class BruteForceProtection
  MAX_LOGINS_PER_MIN = 15

  attr_accessor :user, :request, :attacker_ip

  def initialize(request, user)
    @request = request
    @attacker_ip = request.ip

    @user = user
  end

  def deny_request?
    return true unless @user
    UserLogin.logins_last_min(@user.username, @attacker_ip) > MAX_LOGINS_PER_MIN
  end

end
