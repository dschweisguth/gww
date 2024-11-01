const GWW = {}; // eslint-disable-line
GWW.shared = {};

GWW.shared.superior = function (object, funcName) {
  "use strict";

  const superFunc = object[funcName];

  return function () {
    return superFunc.apply(object, arguments);
  };

};
