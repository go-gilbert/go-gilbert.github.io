+++
title = "Syntax"
description = "Creating tasks and pipelines in gilbert.yaml file"
weight = 20
draft = false
toc = true
bref = "This article covers all information about gilbert.yaml syntax and step-by-step task definition guide"
+++

{{<doc-section id="manifest" label="Manifest file" >}}

`gilbert.yaml` it's a [yaml](https://en.wikipedia.org/wiki/YAML) file that contains all information 
about your tasks and tells *Gilbert* what to do when you try to run specific task.

This file should be located at the root folder of your codebase, or at least at the same location where you call `gilbert` command.

Run `gilbert init` command to create a sample *gilbert.yaml* file.

{{<doc-section id="structure" label="Structure" >}}

`gilbert.yaml` consists of tasks, and tasks include a list of jobs to be done and rules.

Here is an annotated example of `gilbert.yaml` file.

```yaml
version: 1.0
imports:
  - ./misc/mixins.yaml
vars:
  appVersion: 1.0.0
tasks:
  build:
  - description: Build project
    action: build
  clean:
  - if: file ./vendor
    description: Remove vendor files
    action: shell
    params:
      command: rm -rf ./vendor
```

**Sections:**

* `version` - file schema version
* `imports` - list of files to import. Imported files should share the same syntax as `gilbert.yaml` file.
* `vars` - list of global variables that available for all tasks and jobs
* `mixins` - mixins. See [mixins](#h-mixins) for more info
* `tasks` - contains a list of tasks. Task can be called by `gilbert run task_name`

{{<doc-section id="variables" label="Variables" >}}

*Gilbert* allows to keep variables in the manifest file and use them in tasks and jobs.

There are 2 type of variables:

* **Global** - defined in `vars` section in root. Available everythere.
* **Local** - defined in specific job and visible only in scope of job.

**Tip:** variable values could be set or changed using [command flags](../commands/#run-task).


#### Predefined variables

By default, there are a few predefined variables in global scope:

- `PROJECT` - Path to the folder where `gilbert.yaml` is located.
- `BUILD` - Alias to `${PROJECT}/build`, can be useful as default build output directory.
- `GOPATH` - Go path environment variable

{{<doc-section id="h-templates" label="String templates" >}}

All variable values and some other params can contain not only static value, but also template expression.

String template can contain a value of any variable (`{{ var_name }}`) or a value of some shell command (`{% whoami %}`) or both.

**Example:**

```yaml
version: 1.0
vars:
    foo: "{% go version %} is installed on {{ GOROOT }}"
```

The value of variable *foo* will be:<br />
`go version go1.10.1 linux/amd64 is installed on /usr/local/go`


{{<doc-section id="tasks" label="Tasks" >}}

Each task is located in `tasks` section and contains from a sequence of
jobs that should be ran when task was called.

#### Job definiton

Each job should contain a subject to call - action, task or mixin.
Most of parameters are *optional*.

```yaml
tasks:
  build_project:
  - action: build                     # name of action to perform, required!
    description: "build the project"  # step description, optional
    delay: 500                        # delay before step start in milliseconds, optional
    vars:
      commit: "{% git log --format=%H -n 1 %}"     # Variables for current step, optional
      foo: "bar"
    params:                                           # Arguments for action.
      variables:                                      # Those values are specific
          'main.version': "{{ commit }}"              # to each action.
          'main.stable': 'true'
  
  # Call sub-task
  - if: '[ $(uname -s) == "Darwin" ]'    # Condition for step run, contains a shell command, optional
    task: build-for-mac
    vars:
      dist_dir: '/tmp'  # variable `dist_dir` will be passed to 'build-for-mac' task
```

#### Job fields

<table>
  <tr>
      <th>Param name</th>
      <th>Type</th>
      <th>Description</th>
  </tr>
  <tr>
      <td>`if`</td>
      <td><i>boolean</i></td>
      <td>Contains conditional shell command. If command returns non-zero exit code, step will be skipped</td>
  </tr>
  <tr>
      <td>`description`</td>
      <td><i>string</i></td>
      <td>Contains step description and makes your job run status more informative</td>
  </tr>
  <tr>
      <td class="param-required">`action`</td>
      <td><i>string</i></td>
      <td>Name of action to execute. See <a href="../actions">built-in actions</a> for more info</td>
  </tr>
  <tr>
      <td class="param-required">`task`</td>
      <td><i>string</i></td>
      <td>Name of task to be called. <b>Cannot be together</b> with `action` not `mixin` in the same job.</td>
  </tr>
  <tr>
      <td class="param-required">`mixin`</td>
      <td><i>string</i></td>
      <td>Name of the mixin to be called. <b>Cannot be together</b> with `action` nor `task` in the same job.</td>
  </tr>
  <tr>
      <td>`async`</td>
      <td><i>boolean</i></td>
      <td>Run job asynchronously. Useful for executing programs like _web-servers_, etc.</td>
  </tr>
  <tr>
      <td>`delay`</td>
      <td><i>int</i></td>
      <td>Delay before step start in milliseconds</td>
  </tr>
  <tr>
      <td>`deadline`</td>
      <td><i>int</i></td>
      <td>Job execution deadline in milliseconds</td>
  </tr>
  <tr>
      <td>`vars`</td>
      <td><i>dict</i></td>
      <td>List of local variables for the step, work the same as global <code>vars</code> section.</td>
  </tr>
  <tr>
      <td class="param-optional">`params`</td>
      <td><i>dict</i></td>
      <td>Contains arguments for the action. See action docs for more info</td>
  </tr>
</table>
<p>
  <span class="param-required"></span> - Required parameter<br />
  <span class="param-optional"></span> - Optional parameter but depends on action<br />
</p>

#### Subtasks

Task can call another tasks and pass or replace variables with own values.

```yaml
tasks:
  start-qa:
    - task: start-server            # call 'start-server' task
      vars:                         # with overrided 'config' variable
        config: ./config-qa.json
  
  start-server:
    - action: shell
      vars:
        config: ./config.json
      params:
        command: './build/server -c {{config}}'
```

{{<doc-section id="mixins" label="Mixins" >}}

Mixin is a set of jobs that can be included into task.<br />
Mixin serves as a template for common actions and used to reduce boilerplate code and do not clutter up tasks list.

Also, one of the biggest differences that most of values can contain template expressions.  

#### Declaration

Each mixin should be declared in `mixins` section and have the same syntax as regular jobs in `tasks` section:

```yaml
  version: 1.0
  mixins:
    hello-world:
      - action: shell
        params:
          command: 'echo "hello world"'
      - action: build
```

#### Calling a mixin

Mixins are called by tasks and use job variables as parameters.
The same mixin can be called several times with different parameters in the same job.

**Example:**

```yaml
version: 1.0
mixins:
  platform-build:
  - action: build
    description: 'build for {{os}} {{arch}}'
      vars:
        extension: '' # variable default value
      params:
        outputPath: '{{buildDir}}/myproject_{{os}}-{{arch}}{{extension}}'
        target:
          os: '{{os}}'
          arch: '{{arch}}'
  - if: 'type md5sum'
    description: 'generate checksum for {{buildDir}}/myproject_{{os}}-{{arch}}{{extension}}'
    action: shell
    vars:
      fileName: 'myproject_{{os}}-{{arch}}{{extension}}'
    params:
      workDir: '{{buildDir}}'
      command: 'md5sum {{fileName}} > {{fileName}}.md5'

tasks:
  release:
  - mixin: platform-build
    vars:
      os: windows
      arch: amd64
      ext: .exe
  - mixin: platform-build
    if: '[ $(uname -s) == "Darwin" ]'
    vars:
      os: darwin
      arch: amd64
```

In example above, task `release` calls mixin `platform-release` and passes variables `os`, `arch` and `ext` to the mixin.

{{<doc-section id="advanced-example" label="Advanced examples" >}}

You can find a good use-case example in <a href="https://github.com/go-gilbert/demo-go-plugins" target="_blank">this demo project</a>.<br />
That repo demonstrates usage of mixins and a few built-in actions for a real-world web-server example.

