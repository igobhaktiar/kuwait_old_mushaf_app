class SettingResponse<Type> {
   String? id;
   String? fontUrl;
   Type? data;
   int? siteNumber;

  SettingResponse({
    this.id,
    this.fontUrl,
    this.data,
    this.siteNumber,
  });
}
