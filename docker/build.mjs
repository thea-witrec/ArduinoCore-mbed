#!/usr/bin/env node

import {default as path} from 'path';
import {default as shell} from 'shelljs';
import {fileURLToPath} from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const baseDir = path.dirname(__dirname);
const distDir = path.join(baseDir, 'dist');
const dockerFile = path.join(baseDir, 'docker', 'Dockerfile');
const imageName = 'arduino-core-mbed-build';

const volumes = [
  [distDir, '/arduino/dist'],
]
  .map(([l, r]) => `-v "${l}:${r}"`)
  .join(' ');

shell.set('-e');

shell.echo('Building docker build container');
shell.exec(`docker build -t ${imageName} -f ${dockerFile} .`);

shell.rm('-rf', distDir);
shell.mkdir('-p', distDir);

shell.exec(`docker run --rm ${volumes} ${imageName}`);
