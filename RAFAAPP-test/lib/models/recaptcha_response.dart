class RecaptchaResponse {
  final bool success;

  final double score;

  final String action;

  final DateTime challengeTimeStamp;

  final String hostname;

  final List<String>? errorCodes;

  RecaptchaResponse(
      {required this.success,
      required this.score,
      required this.action,
      required this.challengeTimeStamp,
      required this.hostname,
      this.errorCodes});

  factory RecaptchaResponse.fromJson(Map<String, dynamic> json) {
    return RecaptchaResponse(
        success: json["success"],
        score: json["score"],
        action: json["action"],
        challengeTimeStamp: DateTime.parse(json["challenge_ts"]),
        hostname: json["hostname"],
        errorCodes: json["error-codes"]);
  }
}
