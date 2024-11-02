var GWW = {}; // eslint-disable-line no-redeclare
GWW.shared = {};

GWW.shared.superior = function (object, funcName) {
  "use strict";

  const superFunc = object[funcName];

  return function () {
    return superFunc.apply(object, arguments);
  };

};
