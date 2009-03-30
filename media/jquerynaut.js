// Simply overwrites prototype specific functions 
// with jquery specific versions 

Juggernaut.fn.fire_event = function(fx_name) {
     $(document).trigger("juggernaut:" + fx_name);
   };

Juggernaut.fn.bindToWindow = function() {
    $(window).bind("load", this, function(e) {
      juggernaut = e.data;
      e.data.appendFlashObject();
    });
  };

Juggernaut.toJSON = function(hash) {
    return $.toJSON(hash) ;
  };

Juggernaut.parseJSON = function(string) {
    return $.parseJSON(string);
  };

Juggernaut.fn.swf = function(){
    return $('#' + this.options.swf_name)[0];
  };
  
Juggernaut.fn.appendElement = function() {
    this.element = $('<div id=juggernaut>');
    $("body").append(this.element);
  };

Juggernaut.fn.refreshFlashObject = function(){
    $(this.swf()).remove();
    this.appendFlashObject();
  };

Juggernaut.fn.reconnect = function(){
    if(this.options.reconnect_attempts){
      this.attempting_to_reconnect = true;
      this.fire_event('reconnect');
      this.logger('Will attempt to reconnect ' + this.options.reconnect_attempts + ' times, the first in ' + (this.options.reconnect_intervals || 3) + ' seconds');
      var self = this;
      for(var i=0; i < this.options.reconnect_attempts; i++){
        setTimeout(function(){
          if(!self.is_connected){
            self.logger('Attempting reconnect');
            if(!self.ever_been_connected){
              self.refreshFlashObject();
            } else {
              self.connect();
            }
          }
        }, (this.options.reconnect_intervals || 3) * 1000 * (i + 1));
        
      }
    }
  };
