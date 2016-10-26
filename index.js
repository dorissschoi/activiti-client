module.exports = {
  escape: function(html) {
    return String(html)
      .replace(/&/g, '&amp;')
      .replace(/>/g, '&gt;');
  },

  /**
   * Unescape special characters in the given string of html.
   *
   * @param  {String} html
   * @return {String}
   */
  unescape: function(html) {
    return String(html)
      .replace(/&amp;/g, '&')
      .replace(/&gt;/g, '>');
  }
};