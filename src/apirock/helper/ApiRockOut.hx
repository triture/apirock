package apirock.helper;

class ApiRockOut {

    private static var TAB:String = "    ";

    private static var ccode = '\033[0m';
    private static var red = ['[red]', '[/red]', '\033[0;31m'];
    private static var cyan = ['[cyan]', '[/cyan]', '\033[0;36m'];
    private static var green = ['[green]', '[/green]', '\033[0;32m'];
    private static var yellow = ['[yellow]', '[/yellow]', '\033[0;33m'];

    static public function printWithTab(text:String, tabs:Int):Void print(repeat(TAB, tabs) + text);

    static public function printIndex(index:String, text:String):Void {
        var count:Int = index.split(".").length - 1;
        printWithTab(index + " " + text, count);
    }

    static public function printTitle(text:String):Void {
        var clean:String = getCleanInfo(text);

        print(TAB);
        print(TAB + text.toUpperCase());
        print(TAB + repeat("=", clean.length));
        print(TAB);
    }

    static public function printBox(text:String):Void {
        var clean:String = getCleanInfo(text);
        var len:Int = clean.length + TAB.length * 2 + 2;

        var line:String = repeat("-", len);
        var emptyLine:String = "|" + repeat(" ", TAB.length * 2 + clean.length) + "|";
        var content:String = "|" + TAB + text + TAB + "|";

        print(TAB + line);
        print(TAB + emptyLine);
        print(TAB + content);
        print(TAB + emptyLine);
        print(TAB + line);
    }

    static public function print(info:String):Void {
        info = info.split(red[0]).join(red[2]).split(red[1]).join(ccode);
        info = info.split(cyan[0]).join(cyan[2]).split(cyan[1]).join(ccode);
        info = info.split(green[0]).join(green[2]).split(green[1]).join(ccode);
        info = info.split(yellow[0]).join(yellow[2]).split(yellow[1]).join(ccode);

        Sys.println(info);
    }

    static private function getCleanInfo(info:String):String {
        info = info.split(red[0]).join('').split(red[1]).join('');
        info = info.split(cyan[0]).join('').split(cyan[1]).join('');
        info = info.split(green[0]).join('').split(green[1]).join('');
        info = info.split(yellow[0]).join('').split(yellow[1]).join('');
        return info;
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
