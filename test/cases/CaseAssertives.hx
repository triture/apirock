package cases;

import apirock.assert.Assertives;
import utest.Assert;
import utest.Test;

@:access(apirock.assert.Assertives)
class CaseAssertives extends Test {
    
    function testCompareSameTypes() {
        var a:Assertives = new Assertives();
        
        Assert.isTrue(a.compareStrings("", ""));
        Assert.isTrue(a.compareInts(0, 0));
        Assert.isTrue(a.compareArrays([], []));
        Assert.isTrue(a.compareFloats(0.1, 0.1));
        Assert.isTrue(a.compareObjects({}, {}));
        Assert.isTrue(a.compareBools(true, true));

    }

    function testCompareWrongTypes() {
        var a:Assertives = new Assertives();

        Assert.isFalse(a.compareValues("", null));
        Assert.isFalse(a.compareValues("", 0));
        Assert.isFalse(a.compareValues("", []));
        Assert.isFalse(a.compareValues("", 0.1));
        Assert.isFalse(a.compareValues("", {}));
        Assert.isFalse(a.compareValues("", true));
        
        Assert.isFalse(a.compareValues(0, null));
        Assert.isFalse(a.compareValues(0, ""));
        Assert.isFalse(a.compareValues(0, []));
        Assert.isFalse(a.compareValues(0, {}));
        Assert.isFalse(a.compareValues(0, true));

        Assert.isFalse(a.compareValues([], null));
        Assert.isFalse(a.compareValues([], ""));
        Assert.isFalse(a.compareValues([], 0));
        Assert.isFalse(a.compareValues([], 0.1));
        Assert.isFalse(a.compareValues([], {}));
        Assert.isFalse(a.compareValues([], true));

        Assert.isFalse(a.compareValues(0.1, null));
        Assert.isFalse(a.compareValues(0.1, ""));
        Assert.isFalse(a.compareValues(0.1, []));
        Assert.isFalse(a.compareValues(0.1, {}));
        Assert.isFalse(a.compareValues(0.1, true));
        
        Assert.isFalse(a.compareValues({}, null));
        Assert.isFalse(a.compareValues({}, ""));
        Assert.isFalse(a.compareValues({}, 0));
        Assert.isFalse(a.compareValues({}, []));
        Assert.isFalse(a.compareValues({}, 0.1));
        Assert.isFalse(a.compareValues({}, true));

        Assert.isFalse(a.compareValues(true, null));
        Assert.isFalse(a.compareValues(true, ""));
        Assert.isFalse(a.compareValues(true, 0));
        Assert.isFalse(a.compareValues(true, []));
        Assert.isFalse(a.compareValues(true, 0.1));
        Assert.isFalse(a.compareValues(true, {}));

    }

    function testCompareValues() {
        var a:Assertives = new Assertives();

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
    
    function testArrayAccessToCompare() {
        var a:Assertives = new Assertives();

        var receivedData:Dynamic = {
            a : 0,
            b : [1, 2, 3],
            c : [
                {ca:0},
                {ca:1},
                {ca:2}
            ]
        }

        Assert.isTrue(a.compareValues({
            a : 0,
            b : [1, 2, 3],
            c : [
                {ca:0},
                {ca:1},
                {ca:2}
            ]
        }, receivedData));

        Assert.isTrue(a.compareValues({
            a : 0,
            'b[1]' : 2
        }, receivedData));

        Assert.isTrue(a.compareValues({
            a : 0,
            'c[1]' : {ca:1},
            'c[2]' : {ca:2}
        }, receivedData));

        Assert.isTrue(a.compareValues({
            a : 0,
            'b[?]' : 2,
            'b[?]' : 3,
            'c[?]' : {ca:2}
        }, receivedData));

        Assert.isFalse(a.compareValues({
            a : 0,
            'b[?]' : 2,
            'c[?]' : {ca:3}
        }, receivedData));
    }

    function testCompareComplexValue() {
        var a:Assertives = new Assertives();
        var receivedData:Dynamic = {
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

        Assert.isTrue(a.compareValues({
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
        }, receivedData
        ));

        Assert.isFalse(a.compareValues({
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
        }, receivedData
        ));

        Assert.isFalse(a.compareValues({
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
        }, receivedData
        ));

        Assert.isFalse(a.compareValues({
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
        }, receivedData
        ));

    }


}