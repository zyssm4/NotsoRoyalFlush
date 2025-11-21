const { app, BrowserWindow, Menu } = require('electron');
const path = require('path');

let mainWindow;

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1280,
        height: 800,
        minWidth: 800,
        minHeight: 600,
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            enableRemoteModule: false
        },
        icon: path.join(__dirname, 'assets', 'icon.png'),
        title: 'Royal Rush',
        backgroundColor: '#1e3c72'
    });

    // Load the game
    mainWindow.loadFile('index.html');

    // Create application menu
    const template = [
        {
            label: 'Game',
            submenu: [
                {
                    label: 'New Game',
                    accelerator: 'CmdOrCtrl+N',
                    click: () => {
                        mainWindow.reload();
                    }
                },
                { type: 'separator' },
                {
                    label: 'Quit',
                    accelerator: 'CmdOrCtrl+Q',
                    click: () => {
                        app.quit();
                    }
                }
            ]
        },
        {
            label: 'View',
            submenu: [
                { role: 'reload' },
                { role: 'forceReload' },
                { type: 'separator' },
                { role: 'togglefullscreen' }
            ]
        },
        {
            label: 'Help',
            submenu: [
                {
                    label: 'About',
                    click: () => {
                        const aboutWindow = new BrowserWindow({
                            width: 400,
                            height: 300,
                            parent: mainWindow,
                            modal: true,
                            show: false,
                            webPreferences: {
                                nodeIntegration: true,
                                contextIsolation: false
                            }
                        });

                        aboutWindow.loadURL(`data:text/html;charset=utf-8,
                            <html>
                                <head>
                                    <style>
                                        body {
                                            font-family: Arial, sans-serif;
                                            display: flex;
                                            flex-direction: column;
                                            justify-content: center;
                                            align-items: center;
                                            height: 100vh;
                                            margin: 0;
                                            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
                                            color: white;
                                        }
                                        h1 { margin: 10px 0; }
                                        p { margin: 5px 0; }
                                    </style>
                                </head>
                                <body>
                                    <h1>Royal Rush</h1>
                                    <p>Version 1.0.0</p>
                                    <p>Build the perfect Royal Flush!</p>
                                    <p style="margin-top: 20px; opacity: 0.8;">© 2025</p>
                                </body>
                            </html>
                        `);

                        aboutWindow.setMenu(null);
                        aboutWindow.once('ready-to-show', () => {
                            aboutWindow.show();
                        });
                    }
                }
            ]
        }
    ];

    // Add Developer menu in development
    if (process.env.NODE_ENV === 'development' || !app.isPackaged) {
        template.push({
            label: 'Developer',
            submenu: [
                { role: 'toggleDevTools' }
            ]
        });
    }

    const menu = Menu.buildFromTemplate(template);
    Menu.setApplicationMenu(menu);

    // Open DevTools in development mode
    if (process.env.NODE_ENV === 'development' || !app.isPackaged) {
        // mainWindow.webContents.openDevTools();
    }

    mainWindow.on('closed', () => {
        mainWindow = null;
    });
}

// App lifecycle
app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        createWindow();
    }
});

// Prevent multiple instances
const gotTheLock = app.requestSingleInstanceLock();

if (!gotTheLock) {
    app.quit();
} else {
    app.on('second-instance', () => {
        if (mainWindow) {
            if (mainWindow.isMinimized()) mainWindow.restore();
            mainWindow.focus();
        }
    });
}
