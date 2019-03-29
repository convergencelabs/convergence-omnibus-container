import java.nio.file.Files
import java.io.File

val fetchServerNode = TaskKey[Unit](
  "fetchServerNode",
  "Copy the convergence-server-node universal package to the docker-build dir")

ThisBuild / organization := "io.convergence"
ThisBuild / version      := "1.0.0-rc.1"
ThisBuild / scalaVersion := "2.12.8"
ThisBuild / name         := "convergence-de-container"

lazy val convergenceUberContainer = (project in file("."))
  .settings(
    resolvers += "Convergence Repo" at "https://nexus.dev.int.convergencelabs.tech/repository/maven-all/",
    libraryDependencies ++= Seq (
      "com.convergencelabs" % "convergence-server-node" % "1.0.0-rc.1" artifacts(Artifact("convergence-server-node", "tgz", "tgz")) from "https://nexus.dev.int.convergencelabs.tech/repository/maven-convergence-releases/com/convergencelabs/convergence-server-node/1.0.0-rc.1/convergence-server-node-1.0.0-rc.1.tgz"
    ),
    fetchServerNode := {
      val dockerBuildDir = new File("docker-build");
      if (!dockerBuildDir.exists) {
        dockerBuildDir.mkdir()
      }

      val targetFile = new File(dockerBuildDir, "convergence-server-node.tgz")
      if (targetFile.exists) {
        targetFile.delete()
      }

      val log = streams.value.log
      val cReport = (update in Compile).value.configuration(Compile).get
      cReport
        .modules
        .filter(mReport => mReport.module.name.startsWith("convergence-server-node"))
        .foreach { mReport =>
          mReport.artifacts.foreach { case (art, f) =>
            log.info(s"Copying ${f} to ${targetFile}")
            Files.copy(f.toPath, targetFile.toPath)
        }
      }
    }
  )
