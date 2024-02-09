const std = @import("std");
const fs = std.fs;
const Metadata = fs.File.Metadata;
const PermissionUnix = fs.File.PermissionsUnix;

pub fn main() !void {
    const BufferSize = 100;
    var out_buffer: [BufferSize]u8 = undefined;
    const out_result = try std.process.getCwd(&out_buffer);

    const dir = fs.cwd();
    const opened_dir = try dir.openDir(out_result, .{ .iterate = true });
    const metadata = try opened_dir.metadata();
    const permission = metadata.permissions();
    _ = permission;

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
            // here are several things that we need in order to have same output
            // as ls shell command
            // 1. check whether current item a directory
            // 2. get pemission
            // 3. If current item is directory, get all item count inside that directory
            // 4. Get owner and group owner for this current item
            // 5. Get size
            // 6. Get last modified date
            // 7. Get last modified time
            // 8. Get item's name
            const item_is_dir =
                if (item.kind == .directory) true else false;
            if (item_is_dir) {
                const dir_metadata = try item.dir.metadata();
                const dir_permission = dir_metadata.permissions();
                const platform_permission: PermissionUnix = dir_permission.inner;
                _ = platform_permission;
                // const typeInfo = @typeInfo(PermissionUnix.Class)
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

pub fn get_all_permissions(comptime enumType: type) void {
    const enum_fields = std.meta.fields(enumType);
    inline for (enum_fields) |enum_field| {
        std.debug.print("{}\n", .{enum_field});
    }
}

const LsInfo = struct {
    metadata: []u8, // item type and permission
    item_count: usize,
    user: []u8,
    group: []u8,
    size: u32,
    data: usize,
    clock: usize,
    basename: []u8,
    is_dir: bool,
};

test "Testing inline for PemsissionUnix.Class type" {
    const typeInfo = @typeInfo(PermissionUnix.Class);
    const typeInfoFields = typeInfo.Enum.fields;

    const metaFields = std.meta.fields(PermissionUnix.Class);

    try std.testing.expectEqual(@TypeOf(typeInfoFields), @TypeOf(metaFields));

    inline for (typeInfoFields, metaFields) |tif, mf| {
        try std.testing.expectEqual(tif, mf);
    }
}

test "get_all_permissions compiles" {
    get_all_permissions(PermissionUnix.Class);
}
