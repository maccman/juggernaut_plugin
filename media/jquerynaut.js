// Simply overwrites prototype specific functions 
// with jquery specific versions 

Juggernaut.fn.fire_event = function(fx_name) {
     $(document).trigger("juggernaut:" + fx_name);
   }

Juggernaut.fn.bindToWindow = function() {
    $(window).bind("load", this, function(e) {
      juggernaut = e.data;
      e.data.appendFlashObject()
    });
  }

Juggernaut.toJSON = function(hash) {
    return $.toJSON(hash) ;
  } 

Juggernaut.parseJSON = function(string) {
    return $.parseJSON(string);
  }

Juggernaut.fn.swf = function(){
    return $('#' + this.options.swf_name)[0];
  }
  
Juggernaut.fn.appendElement = function() {
    this.element = $('<div id=juggernaut>');
    $("body").append(this.element);
  }
