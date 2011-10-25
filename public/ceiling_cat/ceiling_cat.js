(function(scope){
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };


  /**
   * See Readme.md for usage
   **/
  scope.CeilingCat = (function() {
    var TTL = 15;

    function CeilingCat(url,me,cb) {
      this.url = url;
      if (cb) {
        this.cb = cb;
        this.me = me;
      } else {
        this.cb = me;
      }
      this.info = function() {};
      this.key = document.location.href;
      this.liveFor = TTL;
    }

    CeilingCat.prototype.stillSeesMe = function() {
      var self = this;
      
      $.ajax({
        url: this.url+'/sees/'+this.me,
        type: "GET",
        dataType: 'json',
        data: {
          key: document.location.href,
          data: this.info(),
          ttl: this.liveFor||TTL
        },
        success: function(data) {
          self.liveFor = data.ttl;
          var timeout = (data.ttl-5)*1000
          self.timeout = setTimeout(__bind(self.stillSeesMe,self),timeout);
          self.cb(data);
        }
      });
    };

    CeilingCat.prototype.hides = function() {
      clearTimeout(this.timeout);
    };

    CeilingCat.prototype.seesMe = function() {
      this.stillSeesMe();
    };

    function setLastAction() {
      CeilingCat.lastActionAt = new Date();
    }
    $(document).bind('click',setLastAction).bind('keyup',setLastAction).bind('scroll',setLastAction);

    return CeilingCat
  })();
})(this)
