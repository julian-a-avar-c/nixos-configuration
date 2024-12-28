#!/usr/bin/env -S scala-cli shebang -S 3.3.4

//> using scala 3.3.4
//> using platform scala-native
//> using nativeVersion 0.5.6

//> using option -deprecation
//> using option -language:strictEquality
//> using option -Yexplicit-nulls
//> using option -Wvalue-discard
//> using option -Wnonunit-statement
//> using option -Wconf:msg=(unused.*value|discarded.*value|pure.*statement):error

//> using dep com.lihaoyi::mainargs::0.7.6
//> using dep com.lihaoyi::os-lib::0.11.3

package mnc

import mainargs.*

import scala.scalanative.posix.unistd.geteuid

object Main {
  import util.*

  def main(args: Array[String]): Unit =
    val _ = ParserForMethods(this).runOrExit(args)
  @main def `save-progress`() = println { Command.`save-progress`.call() }
  @main def `update-everything`() = println {
    Command.`update-everything`.callAll()
  }
  @main def `list-generations`() = println { Command.`list-generations`.call() }
  @main def `last-generation`()  = println { Command.`last-generation`.call() }
  @main def `clean`()            = println { Command.`clean`.call() }
}

object Command {
  import util.*

  val `save-progress` = proc"git add ."
  val `update-everything` =
    Seq(
      Seq(`save-progress`),
      if geteuid() != 0
      then Seq(os.proc("echo", "\"Please run as root to update NixOS\""))
      else
        Seq(
          `last-generation`,
          proc"nixos-rebuild switch --show-trace --flake .",
          `last-generation` | proc"tail --lines=1",
        ),
    ).flatten
  val `list-generations` = proc"nixos-rebuild list-generations"
  val `last-generation`  = `list-generations` | proc"head -2"
  val `clean`            = proc"rm -rf .bsp .metals .scala-build"
}

package util {
  extension [A, B](f: A => B) def |>[C](g: B => C) = (a: A) => g(f(a))

  extension (sc: StringContext)
    def proc(args: Any*): os.proc =
      os.proc(sc.s(args*).split(" ").nn.toSeq.map(_.nn)*)

  extension (procA: os.proc | os.ProcGroup)
    infix def ++(procB: os.proc | os.ProcGroup): Seq[os.proc] =
      (procA, procB) match
        case (os.ProcGroup(procsA), os.ProcGroup(procsB)) => procsA ++ procsB
        case (os.ProcGroup(procsA), procB: os.proc)       => procsA :+ procB
        case (procA: os.proc, os.ProcGroup(procsB))       => procA +: procsB
        case (procA: os.proc, procB: os.proc)             => Seq(procA, procB)

    infix def |(procB: os.proc | os.ProcGroup): os.ProcGroup =
      val allProcs = procA ++ procB
      val (first, second, tail) = allProcs match
        case Seq(first, second)        => (first, second, Seq.empty)
        case Seq(first, second, tail*) => (first, second, tail)
        // There's always at least two processes
        case _ => ???

      if tail.isEmpty
      then first pipeTo second
      else tail.foldLeft(first pipeTo second) { _ pipeTo _ }
    end |
  end extension

  extension (seq: Seq[os.proc | os.ProcGroup])
    def callAll(): Seq[os.CommandResult] =
      seq.map {
        case proc: os.proc       => proc.call()
        case group: os.ProcGroup => group.call()
      }
    end callAll
  end extension
}
