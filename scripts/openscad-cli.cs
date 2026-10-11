// Tiny Windows shim: Cursor's OpenSCAD Preview spawns an .exe (not .cmd).
// Injects 3MF color export flags so Blueprint object colors survive preview.
using System;
using System.Diagnostics;
using System.IO;
using System.Text;

class OpenScadCli {
  static int Main(string[] args) {
    string bin = Environment.GetEnvironmentVariable("OPENSCAD_EXE");
    if (string.IsNullOrEmpty(bin) || !File.Exists(bin)) {
      string pf = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles);
      string[] candidates = {
        Path.Combine(pf, "OpenSCAD (Nightly)", "openscad.exe"),
        Path.Combine(pf, "OpenSCAD", "openscad.exe")
      };
      foreach (string c in candidates) {
        if (File.Exists(c)) { bin = c; break; }
      }
    }
    if (string.IsNullOrEmpty(bin) || !File.Exists(bin)) {
      Console.Error.WriteLine("openscad-cli: OpenSCAD executable not found.");
      return 1;
    }

    StringBuilder sb = new StringBuilder();
    sb.Append("-O \"export-3mf/color-mode=model\" -O \"export-3mf/material-type=color\"");
    foreach (string a in args) {
      sb.Append(' ');
      if (a.IndexOfAny(new char[] { ' ', '\t', '"' }) >= 0) {
        sb.Append('"');
        sb.Append(a.Replace("\"", "\\\""));
        sb.Append('"');
      } else {
        sb.Append(a);
      }
    }

    ProcessStartInfo psi = new ProcessStartInfo();
    psi.FileName = bin;
    psi.Arguments = sb.ToString();
    psi.UseShellExecute = false;
    Process p = Process.Start(psi);
    if (p == null) {
      Console.Error.WriteLine("openscad-cli: failed to start " + bin);
      return 1;
    }
    p.WaitForExit();
    return p.ExitCode;
  }
}
