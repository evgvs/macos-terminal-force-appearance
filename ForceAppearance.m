#import <Cocoa/Cocoa.h>

static void SetAppearance(void)
{
    NSAppearance *appearance =
        #ifdef LIGHT_THEME
            [NSAppearance appearanceNamed:NSAppearanceNameAqua];
        #else // DARK
            [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
        #endif

    for (NSWindow *window in NSApp.windows) {
        window.appearance = appearance;
    }
}

__attribute__((constructor))
static void ForceDark(void)
{
    #ifdef LIGHT_THEME
        fprintf(stderr, "*** ForceLight loaded ***\n");
    #else // DARK
        fprintf(stderr, "*** ForceDark loaded ***\n");
    #endif

    dispatch_async(dispatch_get_main_queue(), ^{

        #ifdef LIGHT_THEME
            NSApp.appearance =
                [NSAppearance appearanceNamed:NSAppearanceNameAqua];
        #else // DARK
            NSApp.appearance =
                [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
        #endif

        SetAppearance();

        [[NSNotificationCenter defaultCenter]
            addObserverForName:NSWindowDidBecomeKeyNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *note) {
                        NSWindow *window = note.object;
                        window.appearance =
                            [NSAppearance appearanceNamed:
                            #ifdef LIGHT_THEME
                                NSAppearanceNameAqua];
                            #else // DARK
                                NSAppearanceNameDarkAqua];
                            #endif
                    }];

    #ifdef LIGHT_THEME
        //fprintf(stderr, "*** ForceLight active ***\n");
    #else // DARK
        //fprintf(stderr, "*** ForceDark active ***\n");
    #endif
    });
}
