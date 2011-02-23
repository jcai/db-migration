package db.migration.app;

import db.migration.app.console.ConsoleMigration;
import db.migration.app.ui.DatabaseMigrationUI;

import java.awt.GraphicsEnvironment;



/**
 * 启动应用程序
 * 
 * @author <a href="mailto:jun.tsai@gmail.com">Jun Tsai</a>
 * @version $Revision$
 * @since 0.1
 */
public class BootLoader {
    public static void main(final String[] args) throws Exception {
        if(GraphicsEnvironment.isHeadless()) {
           ConsoleMigration.main(args);
        }else {
            DatabaseMigrationUI.main(args);
        }
    }
}
