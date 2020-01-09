package cases;

import apirock.types.StringKeeper;
import utest.Assert;
import utest.Test;

class CaseStringKeeper extends Test {
    
    function testAddGetAndClearData() {
        StringKeeper.clear();

        Assert.equals(StringKeeper.getData('key'), '');
        
        StringKeeper.addData('key', 'value');
        Assert.equals('value', StringKeeper.getData('key'));

        StringKeeper.addData('key', 'value 2');
        Assert.equals('value 2', StringKeeper.getData('key'));

        StringKeeper.addData('#key', 'value');
        Assert.equals('value', StringKeeper.getData('key'));
        Assert.equals('value', StringKeeper.getData('#key'));

        StringKeeper.clear();
        Assert.equals('', StringKeeper.getData('key'));
    }

    function testToString() {
        StringKeeper.clear();

        StringKeeper.addData('key', 'value');
        
        var keeper1:StringKeeper = '#key';
        var keeper2:StringKeeper = 'key';

        Assert.equals('value', keeper1.toString());
        Assert.equals('key', keeper2.toString());

        StringKeeper.clear();
        Assert.equals('#key', keeper1.toString());
    }

    function testAutoConvert() {
        StringKeeper.clear();

        StringKeeper.addData('foo1', 'bar1');
        StringKeeper.addData('foo2', 'bar2');
        
        var keeper1:StringKeeper = '#foo1';
        var keeper2:StringKeeper = '#foo2';

        Assert.equals('bar1', keeper1.toString());
        Assert.equals('#foo1', keeper1.getStringUnparsed());

        var parsed1:String = keeper1;
        Assert.equals('bar1', parsed1);
        Assert.equals('bar1', Std.string(keeper1));

        Assert.equals('bar1', '' + keeper1);
        Assert.equals('foo bar1', 'foo ' + keeper1);
        Assert.equals('bar1 foo', keeper1 + ' foo');
        
        Assert.equals('bar1bar2', Std.string(keeper1 + keeper2));
        Assert.equals('bar2bar1', Std.string(keeper2 + keeper1));
        
        Assert.equals('bar1 bar2', Std.string('#foo1 ' + keeper2));
        Assert.equals('bar1 bar2', Std.string(keeper1 + ' #foo2'));

        Assert.equals('#foo1#foo2', keeper1.getStringUnparsed() + keeper2.getStringUnparsed());
        Assert.equals('#foo1x', keeper1.getStringUnparsed() + 'x');
        Assert.equals('x#foo1', 'x' + keeper1.getStringUnparsed());
    }

    function testAsync(async:utest.Async) {
        StringKeeper.clear();
        
        StringKeeper.addData('foo', 'bar');

        var keeper:StringKeeper = '#foo';

        Assert.equals('bar', keeper);

        haxe.Timer.delay(
            function() {

                StringKeeper.addData('foo', 'none');
                
            }, 50
        );

        haxe.Timer.delay(
            function() {

                Assert.equals('none', keeper);
                Assert.equals('a none', 'a ' + keeper);
                Assert.equals('none a', keeper + ' a');
                
                async.done();
            }, 100
        );
    }
}