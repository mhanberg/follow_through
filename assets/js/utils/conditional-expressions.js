export default {
  if(expr, ifFn, elseFn) {
    let returnValue;

    if (expr) {
      returnValue = ifFn();
    } else if (elseFn) {
      returnValue = elseFn();
    } else {
      returnValue = null;
    }

    return returnValue;
  },
  unless(expr, unlessFn, elseFn) {
    let returnValue;

    if (!expr) {
      returnValue = unlessFn();
    } else if (elseFn) {
      returnValue = elseFn();
    } else {
      returnValue = null;
    }

    return returnValue;
  }
};
