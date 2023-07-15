# Unicode support

Asciio supports Unicode is a work under progress; including support for Asian languages, thanks to the co-developer who writes in these languages, but you may need a font that supports them.

https://github.com/be5invis/Sarasa-Gothic/

![unicode in Asciio](asciio_unicode.png)

![unicode exported](asciio_unicode_cat.png)

In the examples above the box is drawn with unicode characters, the box is oversized by design, it shrinks and expands properly.

![unicode in Asciioshrunk box](asciio_unicode_shrunk.png)

If you want to align Thai, or Arabic, or Hebrew, under normal circumstances, 
the default monospaced font of the system is fine. If you find that it cannot 
be aligned, you can download a font that can align them.

![unicode_thai_alabo_hebrew](unicode_thai_alabo_hebrew.png)

When displayed in exported software, you also need a font that aligns them.

```txt
      .-----.      .----------------.
      | abc |----->| สวัสดีเราเคยพบกัน |
      '-----'      '----------------'
                            |
                            |
                            |
                            |   .---------------.
                            '-->| שלום, נפגשנו  |
                                '---------------'
                                        |
                                        |
      .------------------.              |
      | مرحبا هل التقينا |<-------------'
      '------------------'

```




