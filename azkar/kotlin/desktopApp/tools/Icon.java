// Draws the Azkar icon to a PNG: one ring of beads on the teal the phone app uses, laid out on the
// same 108-unit canvas as androidApp's ic_launcher so the two are the same picture at any size.
//
// An AppImage has to carry an icon, and Linux has nothing like the Mac's icon.swift, so this draws
// it with the JDK the build already needs.
//
//   java Icon.java azkar.png 256
import java.awt.Color;
import java.awt.GradientPaint;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.geom.Ellipse2D;
import java.awt.geom.RoundRectangle2D;
import java.awt.image.BufferedImage;
import java.io.File;
import javax.imageio.ImageIO;

public class Icon {
    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("usage: java Icon.java <file.png> <size>");
            System.exit(1);
        }
        File out = new File(args[0]);
        int size = Integer.parseInt(args[1]);
        double unit = size / 108.0;

        BufferedImage image = new BufferedImage(size, size, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g = image.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);

        // The background, top to bottom, as ic_launcher_background.xml has it.
        g.setPaint(new GradientPaint(0, 0, new Color(0x1A8C80), 0, size, new Color(0x053342)));
        g.fill(new RoundRectangle2D.Double(0, 0, size, size, size * 0.22, size * 0.22));

        // Ten beads, far enough apart to read as one ring and close enough to touch.
        g.setPaint(new GradientPaint(
                (float) (24 * unit), (float) (20 * unit), new Color(0xF8E7C4),
                (float) (84 * unit), (float) (88 * unit), new Color(0xD79B50)));
        double centre = size / 2.0;
        double ring = 25.5 * unit;
        double bead = 8.35 * unit;
        for (int i = 0; i < 10; i++) {
            double angle = Math.PI * 2 * i / 10 - Math.PI / 2;
            double x = centre + Math.cos(angle) * ring;
            double y = centre + Math.sin(angle) * ring;
            g.fill(new Ellipse2D.Double(x - bead, y - bead, bead * 2, bead * 2));
        }
        g.dispose();
        ImageIO.write(image, "png", out);
    }
}
