package db.migration.app.ui;

import java.io.FilterOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import javax.swing.JTextArea;

/**
 * @author <a href="mailto:jun.tsai@gmail.com">Jun Tsai</a>
 * @version $Revision$
 * @since 0.1
 */
public class TeeOutputStream extends FilterOutputStream {
    private boolean recursing;
    private JTextArea log;
    
    /** Creates a new instance of TeeOutputStream */
    public TeeOutputStream(OutputStream out1, JTextArea log)
    {
        super(out1);
        this.log = log;
    }
    
    public void write(int c) throws IOException
    {
        super.write(c);
        if (!recursing) {
           // log.append(String.valueOf(c));
        }
    }
    
    public void write(byte[] buffer, int offset, int length) throws IOException
    {
        try
        {
            recursing = true;
            super.write(buffer, offset, length);
            log.append(new String(buffer, offset, length));
        }
        finally
        {
            recursing = false;
        }
    }
    
    public void flush() throws IOException
    {
        super.flush();
    }
    
    public void close() throws IOException
    {
        super.close();
    }
}
