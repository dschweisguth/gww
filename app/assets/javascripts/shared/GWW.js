var GWW = {};
GWW.shared = {};

GWW.shared.superior = function (object, funcName) {
  "use strict";

  var superFunc = object[funcName];

  return function () {
    return superFunc.apply(object, arguments);
  };

};
