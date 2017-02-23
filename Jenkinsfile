
//  Docker related values:
def dockerTeam     = "ci"
def dockerImage    = "ghe-backup"
def dockerRepo     = "pierone.stups.zalan.do"
def shortImageName = "$dockerRepo/$dockerTeam/$dockerImage"

//  Lizzy related values:
def awsRegion   = "eu-west-1"
def kioAppName  = "ghe-backup-automata"
//def senzaConfig = "cloud-kraken/production.yaml"

//  Deployment values generated by the pipeline:
def buildNumber = "cd${env.BUILD_NUMBER}"
def nextStackVersion
def fullImageName
def imageVersion

properties([
    pipelineTriggers([
      [$class: "GitHubPushTrigger"]
    ])
  ])

node('kraken') {
    stage("Test") {
        checkout scm
        def shortCommit = sh(returnStdout: true, script: "git rev-parse --short HEAD").trim()
        fullImageName = "$shortImageName:$buildNumber-$shortCommit"
        imageVersion = "$buildNumber-$shortCommit"
        /* 000 to distinguish build number and short commit as lizzy allows only letters and numbers in stack name */
        nextStackVersion = "$buildNumber" + "000" + "$shortCommit"
        echo "New image name: $fullImageName"
        echo "New image version: $imageVersion"
        echo "New cf stack version: $nextStackVersion"
    }
}

node('kraken') {
    stage("Test") {
        deleteDir()
        checkout scm
        // run nosetests as in https://github.com/zalando/ghe-backup/blob/master/.travis.yml
        sh "/tools/run :ghe-backup -- nosetests -w python"
    }
}

node('kraken') {
    stage("Build and Push Docker") {
        docker(dockerRepo, fullImageName, "DockerfileAutomata" , false)
    }
}

if (env.BRANCH_NAME == 'master') {
    timeout(time: 60, unit: "MINUTES") {
        /*
        https://issues.jenkins-ci.org/browse/JENKINS-36543
        https://support.cloudbees.com/hc/en-us/articles/226554067-Pipeline-How-to-add-an-input-step-with-timeout-that-continues-if-timeout-is-reached-using-a-default-value
        */
        def userInput = input(
        id: 'Proceed1', message: 'Do you want to deploy?', parameters: [
            [$class: 'BooleanParameterDefinition', defaultValue: false, description: '', name: 'Please confirm you agree with deployment']
        ])

        if (userInput == true) {
            /*
            zalando specific jenkins job that releases the EBS volume to be prepared for the next CF stack
            */
            stage("release EBS volume for next stack") {
                build job: 'ghe-backup/GithubEnterpriseBackupDeleteExistingAutomataStack', propagate: true, wait: true
            }

            /*
            zalando specific jenkins job creates a new CF stack for the backup
            */
            stage("deployment") {
                build job: 'ghe-backup/GithubEnterpriseBackupDeployAutomataStack',
                    parameters: [string(name: 'IMAGE_PATH', value: fullImageName),
                                 string(name: 'SENZA_YAML_FILE', value: 'ghe-backup-ci.yaml'),
                                 string(name: 'KIO_URL', value: 'https://kio.stups.zalan.do'),
                                 string(name: 'KIO_APP', value: 'ghe-backup-automata'),
                                 string(name: 'TAG', value: nextStackVersion),
                                 string(name: 'IMAGE_VERSION', value: imageVersion)],
                     propagate: true, wait: true
            }
        }else{
            echo "Deployment canceled."
        }
    }
}


//  Builds the docker image and returns the full name of the new image:
def docker(String dockerRepo, String fullImageName, String dockerfile, boolean pushImage) {
    def shortCommit = sh(returnStdout: true, script: "git rev-parse --short HEAD").trim()
    sh "/tools/run :stups -- scm-source"
    sh "/tools/run :stups -- echo 'COPY scm-source.json /' >> $dockerfile"

    sh "/tools/run :stups -- pierone login --url $dockerRepo"
    sh "/tools/run :stups -- docker build --rm -t $fullImageName -f $dockerfile ."

    if (pushImage == true) {
        sh "/tools/run :stups -- pierone login --url $dockerRepo"
        sh "docker push $fullImageName"
    }
}
