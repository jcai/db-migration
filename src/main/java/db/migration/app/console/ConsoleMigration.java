package db.migration.app.console;

import java.io.File;
import java.io.FileFilter;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLClassLoader;

import db.migration.app.RailsMigrator;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;

/**
 * 命令行方式的执行脚本
 * 
 * @author <a href="mailto:jun.tsai@gmail.com">Jun Tsai</a>
 * @version $Revision$
 * @since 0.1
 */
public class ConsoleMigration {
    public static void main(final String[] args) throws Exception {
        upgradeByArgs(args);
    }

    public static int upgradeByArgs(final String[] args)
            throws ParseException, MalformedURLException {
        Options options = new Options();
        options.addOption("d", "db_script_dir", true, "数据库脚本的路径");
        options.addOption("c", "config_file_path", true, "配置文件路径");
        options.addOption("h", "help", false, "查看帮助信息");
        options.addOption("v", "version", false, "查看版本信息");

        CommandLineParser parser = new PosixParser();
        CommandLine cmd = parser.parse(options, args);
        if (cmd.hasOption("v")) {
            System.out
                    .println("数据库升级脚本工具(database migration tools) \n    version: "
                            + getVersion()
                            + "\n    author:Jun Tsai");
            return -1;
        }
        if (cmd.hasOption("h") || !cmd.hasOption("d") || !cmd.hasOption("c")
                ) {
            printUsage(options);
            return -1;
        }
        final String dbUpgradePath = cmd.getOptionValue("d");
        if (!new File(dbUpgradePath).exists()
                || !new File(dbUpgradePath).isDirectory()) {
            System.out.println("数据库脚本路径不存在,或者不是文件目录,目录：" + dbUpgradePath);
            printUsage(options);
            return -1;
        }

        final String hbPath = cmd.getOptionValue("c");

        if (!new File(hbPath).exists() || !new File(hbPath).isFile()) {
            System.out.println("配置文件不存在或者不是文件,path:" + hbPath);
            printUsage(options);
            return -1;
        }

        /*
        String entitiesDir = cmd.getOptionValue("e");
        File libRoot = new File(entitiesDir);
        if (!libRoot.exists()) {
            System.out.println("实体jar以及依赖包不存在,目录:" + entitiesDir);
            printUsage(options);
            return -1;
        }

        // read all *.jar files in the lib folder to array
        File[] libs = libRoot.listFiles(new FileFilter() {
            public boolean accept(File dir) {
                String name = dir.getName().toLowerCase();
                return name.endsWith("jar") || name.endsWith("zip");
            }
        });

        URL[] urls = new URL[libs.length];
        // fill the urls array with URLs to library files found in libRoot
        for (int i = 0; i < libs.length; i++) {
            urls[i] = new URL("file", null, libs[i].getAbsolutePath());
        }
        // create a new classloader and use it to load our app.
        classLoader = new URLClassLoader(urls, Thread.currentThread()
                .getContextClassLoader());
        */
        try {
            //Thread.currentThread().setContextClassLoader(classLoader);
            //return DatabaseMigrationMain.doUpgrade(new String[] {hbPath,dbUpgradePath});
            //TODO
            RailsMigrator.migrate(hbPath,dbUpgradePath);
            return 121;
        } // forward the args
        catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
    public static String getVersion() {
        return "0.1";
    }

    private static void printUsage(Options options) {
        HelpFormatter f = new HelpFormatter();
        f.printHelp("db_upgrade [options]", options);
    }
    private static ClassLoader classLoader;
}
