/*
 * modexec.js - An abstraction layer providing more direct execution of Perl modules
 * Copyright (C) 2006-2007  Michael D. Stemle, Jr. and DW Data, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Okay, so for the config section, you'll need to know a couple things.
 *
 * 1) For security reasons, AJAX can never cross domains.  For this reason,
 *    we only use absolute paths for dispensers instead of URLs.
 *
 * 2) Do not put query string parameters on the dispenser URI, if you need to
 *    put special params into all dispenser requests, please use the
 *    request_params key in the ModExecConfig.  This is just another JS object
 *    that you assign your parameters to.
 */
var ModExecConfig = {
  // What is the absolute path to the jslib path that modexec.js is in?
  modexec_path : '/jslib',

  // This is your primary dispenser
  dispenser : '/modexec/dispenser.pl',

  // If you require a separate dispenser for authenticated sessions, this is it
  secure_dispenser : '/modexec/dispenser.pl',

  // If you need to send the same params to all dispenser calls, use this.
  request_params : {}
};

// Our ModExec constructor
function ModExec (auth) {
  // Determine the URI
  this.uri = (auth) ? ModExecConfig.secure_dispenser : ModExecConfig.dispenser;
  this.exec = ModExec_Exec;

  return this;
}

// The execution method for ModExec
function ModExec_Exec (use_module, call_function, args, success_callback, failure_callback) {
  var conn = null;
  var post_data = null;

  post_data = "use_module="+escape(use_module)+"&call_function="+escape(call_function)+"&args=";
  if (args != null) {
    post_data += escape(JSON.stringify(args));
  }

  try {
    conn = new XMLHttpRequest();
  } catch (error) {
    try {
      conn = new ActiveXObject("Microsoft.XMLHTTP");
    } catch (error) {
      return false;
    }
  }
  conn.onreadystatechange = function () {
    var response_obj = null;

    /* If XMLHR object has finished retrieving the data */
    if (conn.readyState == 4) {
      /* If the data was retrieved successfully */
      if (conn.status == 200) {
        response_obj = JSON.parse (conn.responseText);
        if (response_obj.errcode) {
          return failure_callback (response_obj);
        } else {
          return success_callback (response_obj);
        }
      } else if (conn.status != 0) {
        /* IE returns a status code of 0 on some occasions, so ignore this case */
        failure_callback ({errcode:"ERR_UNKNOWN",errstr:conn.statusText});
      }
    }
  }
  conn.open ("POST", this.uri, true);
  conn.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  conn.send (post_data);
}

// Include the JSON reader
try {
  if (!__JSON_JS__) {
    document.write ("<scr"+"ipt language=\"javascript\" type=\"text/javascript\" src=\""+ModExecConfig.modexec_path+"/json.js\"></scr"+"ipt>");
  }
} catch (e) {
  document.write ("<scr"+"ipt language=\"javascript\" type=\"text/javascript\" src=\""+ModExecConfig.modexec_path+"/json.js\"></scr"+"ipt>");
}

try {
  if (On_ModExecReady != null) {
    On_ModExecReady();
  }
} catch (e) {};

