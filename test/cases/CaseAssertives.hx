package cases;

import apirock.assert.Assertives;
import utest.Assert;
import utest.Test;

@:access(apirock.assert.Assertives)
class CaseAssertives extends Test {
    
    function testCompareSameTypes() {
        var a:Assertives = new Assertives(null);

        Assert.isTrue(a.compareTypes(null, null));
        Assert.isTrue(a.compareTypes("", ""));
        Assert.isTrue(a.compareTypes(0, 0));
        Assert.isTrue(a.compareTypes([], []));
        Assert.isTrue(a.compareTypes(0.1, 0.1));
        Assert.isTrue(a.compareTypes({}, {}));
        Assert.isTrue(a.compareTypes(true, true));

    }

    function testCompareWrongTypes() {
        var a:Assertives = new Assertives(null);

        Assert.isFalse(a.compareTypes("", null));
        Assert.isFalse(a.compareTypes("", 0));
        Assert.isFalse(a.compareTypes("", []));
        Assert.isFalse(a.compareTypes("", 0.1));
        Assert.isFalse(a.compareTypes("", {}));
        Assert.isFalse(a.compareTypes("", true));
        
        Assert.isFalse(a.compareTypes(0, null));
        Assert.isFalse(a.compareTypes(0, ""));
        Assert.isFalse(a.compareTypes(0, []));
        Assert.isFalse(a.compareTypes(0, {}));
        Assert.isFalse(a.compareTypes(0, true));

        Assert.isFalse(a.compareTypes([], null));
        Assert.isFalse(a.compareTypes([], ""));
        Assert.isFalse(a.compareTypes([], 0));
        Assert.isFalse(a.compareTypes([], 0.1));
        Assert.isFalse(a.compareTypes([], {}));
        Assert.isFalse(a.compareTypes([], true));

        Assert.isFalse(a.compareTypes(0.1, null));
        Assert.isFalse(a.compareTypes(0.1, ""));
        Assert.isFalse(a.compareTypes(0.1, []));
        Assert.isFalse(a.compareTypes(0.1, {}));
        Assert.isFalse(a.compareTypes(0.1, true));
        
        Assert.isFalse(a.compareTypes({}, null));
        Assert.isFalse(a.compareTypes({}, ""));
        Assert.isFalse(a.compareTypes({}, 0));
        Assert.isFalse(a.compareTypes({}, []));
        Assert.isFalse(a.compareTypes({}, 0.1));
        Assert.isFalse(a.compareTypes({}, true));

        Assert.isFalse(a.compareTypes(true, null));
        Assert.isFalse(a.compareTypes(true, ""));
        Assert.isFalse(a.compareTypes(true, 0));
        Assert.isFalse(a.compareTypes(true, []));
        Assert.isFalse(a.compareTypes(true, 0.1));
        Assert.isFalse(a.compareTypes(true, {}));

    }

    function testCompareValues() {
        var a:Assertives = new Assertives(null);

        Assert.isTrue(a.compareValues(null, null));
        Assert.isTrue(a.compareValues('', ''));
        Assert.isTrue(a.compareValues(0, 0));
        Assert.isTrue(a.compareValues(0.1, 0.1));
        Assert.isTrue(a.compareValues([], []));
        Assert.isTrue(a.compareValues([1], [1]));
        Assert.isTrue(a.compareValues({}, {}));
        Assert.isTrue(a.compareValues({a:1}, {a:1}));
        Assert.isTrue(a.compareValues(true, true));
        Assert.isTrue(a.compareValues(Date.fromString('2020-01-01'), Date.fromString('2020-01-01')));

        Assert.isFalse(a.compareValues('', 'x'));
        Assert.isFalse(a.compareValues(0, 1));
        Assert.isFalse(a.compareValues(0.1, 0.2));
        Assert.isFalse(a.compareValues([1], [2]));
        Assert.isFalse(a.compareValues({a:1}, {a:2}));
        Assert.isFalse(a.compareValues(true, false));
        Assert.isFalse(a.compareValues(true, false));
        Assert.isFalse(a.compareValues(Date.fromString('2020-01-01'), Date.fromString('2019-01-01')));

    }

    function testCompareComplexValue() {
        var a:Assertives = new Assertives(null);
        var ref:Dynamic = {
            a : 0,
            b : 'b',
            c : [
                {
                    c_a : 0.2
                },
                {
                    c_a : 1
                }
            ],
            d : {
                d_a : null,
                d_b : 'x'
            }
        };

        Assert.isTrue(a.compareValues(ref,  {
            a : 0,
            b : 'b',
            c : [
                {
                    c_a : 0.2
                },
                {
                    c_a : 1
                }
            ],
            d : {
                d_a : null,
                d_b : 'x'
            }
        }
        ));

        Assert.isFalse(a.compareValues(ref,  {
            a : 0,
            b : '',
            c : [
                {
                    c_a : 0.2
                },
                {
                    c_a : 1
                }
            ],
            d : {
                d_a : null,
                d_b : 'x'
            }
        }
        ));

        Assert.isFalse(a.compareValues(ref,  {
            a : 0,
            b : 'b',
            c : [
                {
                    c_a : 0.2
                },
                {
                    c_a : 1.1
                }
            ],
            d : {
                d_a : null,
                d_b : 'x'
            }
        }
        ));

        Assert.isFalse(a.compareValues(ref, {
            a : 0,
            b : 'b',
            c : [
                {
                    c_a : 1
                }
            ],
            d : {
                d_a : null,
                d_b : 'x'
            }
        }
        ));

    }


}