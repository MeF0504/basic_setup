// deno run --allow-read test_script.ts
import { TextLineStream } from "https://deno.land/std@0.136.0/streams/mod.ts";


async function get_answer()
{
    const ori_text = await Deno.readTextFile("./four_strings.txt");
    const text_list = ori_text.split('\n');

    const idx = Math.floor(Math.random()*text_list.length);
    const ans = text_list[idx];
    return ans;
}

async function main()
{
    const ans = await get_answer();
    console.log(ans);
    console.log('4 letters;');
    for await (const chunk of Deno.stdin.readable
               .pipeThrough(new TextDecoderStream())  // Unit8Array -> string
              .pipeThrough(new TextLineStream())) {  // 1行ずつに変換
        console.log('4 letters;');
        if (chunk == 'q') {
            console.log('press Enter');
            return;
        }
        else if (chunk.length != 4) {
            continue;
        }
        let res = '';
        for (let i = 0; i < chunk.length; i++) {
            const ch = chunk[i];
            if (ch == ans[i]) {
                res += 'o';
            } else if (ans.indexOf(ch) != -1) {
                res += '~';
            } else {
                res += 'x';
            }
        }
        console.log(res);
        if (res == 'oooo') {
            console.log('Great!');
            console.log('press Enter');
            break;
        }
    }
}

main()
