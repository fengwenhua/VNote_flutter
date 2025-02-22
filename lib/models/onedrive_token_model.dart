/// [OneDriveTokenModel] 用于解析 OneDrive 返回关于 token 的内容
class OneDriveTokenModel {
	String accessToken;
	String refreshToken;
	String scope;
	int extExpiresIn;
	String tokenType;
	int expiresIn;

	OneDriveTokenModel({this.accessToken, this.refreshToken, this.scope, this.extExpiresIn, this.tokenType, this.expiresIn});

	OneDriveTokenModel.fromJson(Map<String, dynamic> json) {
		accessToken = json['access_token'];
		refreshToken = json['refresh_token'];
		scope = json['scope'];
		extExpiresIn = json['ext_expires_in'];
		tokenType = json['token_type'];
		expiresIn = json['expires_in'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['access_token'] = this.accessToken;
		data['refresh_token'] = this.refreshToken;
		data['scope'] = this.scope;
		data['ext_expires_in'] = this.extExpiresIn;
		data['token_type'] = this.tokenType;
		data['expires_in'] = this.expiresIn;
		return data;
	}
}
