package apirock.helper;

class ApiRockOut {

    private static var TAB:String = "    ";

    static public function printWithTab(text:String, tabs:Int):Void print(repeat(TAB, tabs) + text);

    static public function printIndex(index:String, text:String):Void {
        var count:Int = index.split(".").length - 1;
        printWithTab(index + " " + text, count);
    }

    static public function printTitle(text:String):Void {
        print(TAB);
        print(TAB + text.toUpperCase());
        print(TAB + repeat("=", text.length));
        print(TAB);
    }

    static public function printBox(text:String):Void {
        var len:Int = text.length + TAB.length * 2 + 2;

        var line:String = repeat("-", len);
        var emptyLine:String = "|" + repeat(" ", TAB.length * 2 + text.length) + "|";
        var content:String = "|" + TAB + text + TAB + "|";

        print(TAB + line);
        print(TAB + emptyLine);
        print(TAB + content);
        print(TAB + emptyLine);
        print(TAB + line);
    }

    static public function print(info:String):Void {
        Sys.println(info);
    }

    static public function printList(data:Array<String>, tabs:Int):Void {
        for (item in data) printWithTab('- ' + item, tabs);
    }

    static private function repeat(char:String, len:Int):String {
        var result:String = "";

        for (i in 0 ... len) result += char;

        return result;
    }

}
