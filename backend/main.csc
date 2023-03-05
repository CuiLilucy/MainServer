import codec.sha256 as sha256
import codec.json as json
import process

var backend_path = "/home/cl/backend"
var workspace_path = "/home/cl/workspace"

var enable_log = true
var stdlog = iostream.fstream(backend_path + "/logs/main.log", iostream.openmode.app)

function time_padding(obj, width)
    var time = to_string(obj)
    var last = width - time.size
    if last <= 0
        return time
    end
    var str = new string
    foreach it in range(last) do str += "0"
    return str + time
end

function log(msg)
    if enable_log
        var tm = runtime.local_time()
        stdlog.print("[" + time_padding(tm.year + 1900, 4) + "." + time_padding(tm.mon + 1, 2) + "." + time_padding(tm.mday, 2) + " " + time_padding(tm.hour, 2) + ":" + time_padding(tm.min, 2) + ":" + time_padding(tm.sec, 2) + "]: ")
        stdlog.println(msg)
    end
end

function print_welcome()
    system.out.println("<p>Welcome to Emotional Diary Server!</p>")
    system.out.println("<p>Copyright (C) Lucy 2023</p>")
end

if context.cmd_args.size == 1
    print_welcome()
    system.exit(0)
end

function get_post_body()
    return json.to_var(json.from_stream(system.in))
end

log("Receiving new request, method = " + context.cmd_args[1])

switch context.cmd_args[1]
    default
        system.out.println("<p>ERROR! Non-exist parameter.")
        print_welcome()
    end
    case "facial_classification"
        var body = get_post_body()
        var hash = sha256.hash_str(body.img)
        var p = null
        if !system.file.exist(workspace_path + "/images/" + hash)
            var ofs = iostream.ofstream(workspace_path + "/images/" + hash)
            ofs.print(body.img)
            p = process.exec("docker", {"exec", "facial", "/workspace/upload/run_instance.sh", hash})      
        else
            p = process.exec("docker", {"exec", "facial", "/workspace/upload/run_nocache.sh", hash})
        end
        p.wait()
        system.out.print(p.out().getline())
    end
end