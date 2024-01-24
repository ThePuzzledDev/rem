// Copyright (C) 2021-2023 Chadwain Holness
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const rem_lib = b.addStaticLibrary(.{
        .name = "rem",
        .root_source_file = .{ .path = "rem.zig" },
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(rem_lib);

    {
        const rem_unit_tests = b.addTest(.{
            .name = "rem-unit-tests",
            .root_source_file = .{ .path = "rem.zig" },
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(rem_unit_tests);

        const rem_unit_tests_run = b.addRunArtifact(rem_unit_tests);
        rem_unit_tests_run.step.dependOn(&rem_unit_tests.step);

        const rem_unit_tests_run_step = b.step("test", "Run unit tests");
        rem_unit_tests_run_step.dependOn(&rem_unit_tests_run.step);
    }

    b.addModule("rem", .{ .source_file = .{ .path = "rem.zig" } });

    {
        const json_data = b.pathFromRoot("tools/character_reference_data.json");
        const output_path = b.pathFromRoot("source/named_characters.zig");
        const generate_named_characters = b.addExecutable(.{
            .name = "generate-named-characters",
            .root_source_file = .{ .path = "tools/generate_named_characters.zig" },
            .target = target,
            .optimize = .Debug,
        });

        const generate_named_characters_run = b.addRunArtifact(generate_named_characters);
        generate_named_characters_run.addArgs(&.{ json_data, output_path });

        const generate_named_characters_run_step = b.step("generate-named-characters", "Generate the named character reference data");
        generate_named_characters_run_step.dependOn(&generate_named_characters_run.step);
    }
}
