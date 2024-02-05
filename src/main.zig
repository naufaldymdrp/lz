const std = @import("std");
const fs = std.fs;

pub fn main() !void {
    const BufferSize = 100;
    var out_buffer: [BufferSize]u8 = undefined;
    const out_result = try std.process.getCwd(&out_buffer);

    const dir = fs.cwd();
    const opened_dir = try dir.openDir(out_result, .{ .iterate = true });

    // debug print
    std.debug.print("{s}\n", .{out_result});

    var counter: usize = 0;
    var dir_walker = try opened_dir.walk(std.heap.page_allocator);
    defer dir_walker.deinit();
    while (dir_walker.next()) |opt_item| {
        if (opt_item) |item| {
            if (std.mem.indexOf(u8, item.path, "/")) |_| {
                continue;
            }
            counter += 1;
            std.debug.print("Basename: {s}, Path: {s}, Kind: {}\n", .{ item.basename, item.path, item.kind });
        } else {
            break;
        }
    } else |err| {
        std.debug.print("Err: {}\n", .{err});
        std.debug.print("While loop done", .{});
    }

    std.debug.print("Counter: {}", .{counter});
}
