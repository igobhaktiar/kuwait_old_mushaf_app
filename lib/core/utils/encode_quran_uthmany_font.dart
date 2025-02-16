String findProperFontForPage({required int page}) {
  String outputFontName = page.toString().length == 1
      ? "QCF_P00$page"
      : page.toString().length == 2
          ? "QCF_P0$page"
          : "QCF_P$page";
  return outputFontName;
}
